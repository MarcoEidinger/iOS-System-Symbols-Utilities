# iOS-System-Symbols-Utilities
Utilities around iOS system symbol. Useful for symbolicating iOS crash reports.

Great source and inspiration: https://github.com/Zuikyo/iOS-System-Symbols

## Extract Symbols from Firmware

### Manual (for iOS 13.2+ | Xcode 11+)

1. Download the ipsw firmware (not OTA files), corresponding the system version you need
2. Uncompress the firmware file as zip, find the biggest dmg file(it's the iOS system file image)
6. In the image folder, go to `System/Library/Caches/com.apple.dyld/`, you can either get `dyld_shared_cache_arm64` or `dyld_shared_cache_arm64e`, they are the compressed system frameworks
7. Uncompress `dyld_shared_cache_armxxx` with `dsc_extractor` tool in Apple's dyld project. It is also available in [github.com/Zuikyo/iOS-System-Symbols/tools](https://github.com/Zuikyo/iOS-System-Symbols/tree/master/tools):`./dsc_extractor ./dyld_shared_cache_armxxx ./output`

Source: https://github.com/Zuikyo/iOS-System-Symbols#extract-symbols-from-firmware

## Script

[./tools/downloadSymbols.sh](./tools/downloadSymbols.sh)

Example

```bash
sh tools/downloadSymbols.sh iPhone12,8 latest arm64e
```

## Merge iOS system symbols

To use the same set of symbols to symbolicate crash reports from devices with different CPU architecture (e.g. `arm64` and `arm64`) it is necessary to

1. download arm64 symbols
2. download arm64e symbols and finally
3. merge symbols with `lipo` command => use [merge_symbols.sh](https://github.com/Zuikyo/iOS-System-Symbols/tree/master/tools/merge_symbols.sh) 

Example
```bash
sh tools/merge_symbols.sh <path_to_extracted_arm64e_symbols> <path_to_extracted_arm64_symbols>
```

## List of iOS system symbols

After downloading iOS system symbols you might want to list all
- public frameworks
- private frameworks as well as 
- dynamic libs

### Script

`TODO`

