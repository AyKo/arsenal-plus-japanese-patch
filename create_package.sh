#!/bin/sh
cd $(dirname $0)

cd 'ARS - Base(jp-mt-patch)'
zip -r -9 "../ARS - Base Data(日本語機械翻訳パッチ).ftl" data
cd ..

cd 'ARS - Infinite(jp-mt-patch)'
zip -r -9 "../ARS - Infinite(日本語機械翻訳パッチ).ftl" data
cd ..

cd 'ARS - Ship Pack 1(jp-mt-patch)'
zip -r -9 "../ARS - Ship Pack 1(日本語機械翻訳パッチ).ftl" data
cd ..

cd 'ARS - Ship Pack 2(jp-mt-patch)'
zip -r -9 "../ARS - Ship Pack 2(日本語機械翻訳パッチ).ftl" data
cd ..

cd 'ARS - Ship Pack 3(jp-mt-patch)'
zip -r -9 "../ARS - Ship Pack 3(日本語機械翻訳パッチ).ftl" data
cd ..

zip -0 "Arsenal+English(JapaneseMachineTranslationPatch).zip" \
       "ARS - Base Data(日本語機械翻訳パッチ).ftl" \
       "ARS - Infinite(日本語機械翻訳パッチ).ftl" \
       "ARS - Ship Pack 1(日本語機械翻訳パッチ).ftl" \
       "ARS - Ship Pack 2(日本語機械翻訳パッチ).ftl" \
       "ARS - Ship Pack 3(日本語機械翻訳パッチ).ftl"
