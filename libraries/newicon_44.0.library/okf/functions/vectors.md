# newicon_44.0 vector semantics

All public entries are register-argument calls (a0/a1/d0/d1 +
a6 = newicon base).  Everything forwards to icon.library v44
(`g_icon` at BSS+0) or exec/dos.

## Lifecycle

- **Init** (InitTable initfn, a6=lib): stores SysBase
  (BSS+4); requires `AttnFlags & 2` (AFF_68020); opens
  `icon.library` v44 → BSS+0.  On failure/unsupported CPU:
  `FreeMem(a1=lib-negsize, d0=negsize+possize)` and returns 0.
- **Open** (-6, a6=lib): opens `dos.library` 40 →
  `GetProgramName(buf,1,128)` — on failure falls back to
  `FindTask(0)->ln_Name`; `FilePart`; case-insensitive
  compare vs `"newicons"`; CloseLibrary(dos); refuse (=0)
  when equal.  Otherwise OpenCnt++, clear LIBF_DELEXP
  (flag&=~8), return lib.
- **Close** (-12): OpenCnt--; if 0 && LIBF_DELEXP set →
  expunge path; returns expunge result or 0.
- **Expunge** (-18): if OpenCnt → set flag bit 3
  (LIBF_DELEXP), return 0.  Else CloseLibrary(iconbase),
  `Remove(lib)`, `FreeMem(lib-negsize, negsize+possize)`,
  return seglist (d0 arg = seglist).

## -30 xget(name, lib=a1?, dtype d0, mode d1)

Wait — actual convention: a0=name, others via regs; builds a
12-byte handle `{DiskObject*, imgrec1*, imgrec2*}`:

1. `GetIconTagList(name, {RemapIcon=FALSE,
   TAG_IGNORE/GetDefaultType, DONE})` — **quirk**: the second
   tag is `TAG_IGNORE` when name≠NULL and
   `GetDefaultType=dtype` only when name==NULL (branch sense
   inverted vs intuition).
2. Alloc 12B (MEMF_PUBLIC) tracked via `AddFreeList` on
   `dob->do_FreeList` (+78); then a 22-byte Image alloc
   (flags=2).
3. `IconControlA(dob, {IsPaletteMapped → &mapped})`.
4. If `dob->ga_GadgetRender` (+22) == NULL: install a fresh
   1×1×1 solid `struct Image` (`ImageData` → trailing
   `0xffff` word) — the image alloc from step 2.
5. If !mapped: `FindToolType(dob->do_ToolTypes,
   "DEFAULTIMAGE")` → recurse `xget(tooltype-val, lib, 0, 2)`
   after `FreeDiskObject(this dob)`.  **No recursion guard**
   — a self-referential DEFAULTIMAGE loops forever.
6. Else: 11-tag `IconControlA` get query filling two image
   records (+39/+41 w/h shared, +17/+19 transp pens,
   +21/+23 palettes, +25/+27 palsizes, +29/+31 imagedatas,
   +1 ErrorCode → &v8).  `v8 != 0` → return partial handle.
   flag word per record = `transp != -1 ? 1 : (mode != 0)`.

## -36 put(handle, name)

1. `IconControlA(dob, {IsNativeIcon → &nat})`; if !nat →
   `DupDiskObjectA(dob, NULL)`; fail → 0.
2. img1 flag&2 → skip uploads, d5=1.  Else 7-tag set upload:
   {SetWidth, SetHeight, SetAspectRatio=0x11, SetImageData1,
   SetPalette1, SetPaletteSize1, SetTranspColor1 =
   `flag&1 ? 0 : -1`} — the `bfexts` 1-bit field
   **sign-extends**, so transp-pen-0 == transparency.
   Retcode ≠ 7 → d3=0 (fail).
3. If img2 record present: 4-tag upload {SetImageData2,
   SetPalette2, SetPaletteSize2, SetTranspColor2} (in that
   order).  Retcode ≠ 4 → fail.
4. `PutIconTagList(name, dob, {DropChunkyIconImage=d5&1,
   DropNewIconToolTypes=TRUE, NotifyWorkbench=TRUE})`.
5. If !nat: `FreeDiskObject(dup)`.  Return d3.

## -42 free(handle)

`FreeDiskObject(handle->ni_dob)`; the handle/images ride the
DiskObject's freelist so only the dob is freed.

## -48 getdef(dtype)

`xget(NULL, lib, dtype, 0)` — default icon of a type.

## -54 dupimg(handle)

Alloc 20B via `AddFreeList` freelist; `CopyMem(src=old
imgrec, dst=new, 20)` — wait: copies the 20-byte image
record (w,h,psz,flag,pal,data) — actually **CopyMem copies
20 bytes from the *source image record* at h+4 into the new
block**, then stores new ptr at h+... returns new rec.

## -60 ctrl

Direct forward: `jmp`-equivalent call to iconbase@-156
(IconControlA) with a0/a1 intact.

## -66 mkdef(imgrec, screen?)

`NewDiskObject(3)` → 24B tracked block → 8-tag upload
{w,h,aspect=0x11,data,psz,pal,transp,ErrorCode→&err} →
LayoutIconA(dob, screen, NULL, 1) → CopyMem(rec→block, 20),
store dob at block+20.  err/layout/addfl/alloc failures all
bail via FreeDiskObject and return 0.  **Quirk**: the
AddFreeList size argument is the just-returned allocation
pointer, not a size — register not reloaded (see defects).
