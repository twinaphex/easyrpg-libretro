lib=ICU
ver=67.1
ICU_URL=https://github.com/unicode-org/icu/releases/download/release-${ver//./-}/icu4c-${ver//./_}-src.tgz
ICU_ARGS="--enable-tools=yes --enable-strict=no --disable-tests --disable-samples \
        --disable-dyload --disable-extras --disable-icuio \
        --with-data-packaging=static --disable-layout --disable-layoutex"
