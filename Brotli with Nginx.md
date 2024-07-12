# Configuring Brotli with Nginx

The free and open variant of Nginx does not ship releases with the `ngx-brotli` module present or enabled.
Thus, users seeking to use the brotli compression algorithm to respond to `Accept-Encoding` headers of `br` must compile [google/ngx_brotli][1] against their `nginx` version when they would like to enable it, and whenever `nginx` is updated thereafter.

The instructions present in the installation guide on [google/ngx_brotli][2] are fairly sufficient.

1. Clone the latest version of `nginx` that is installed on your system.

    ```bash
    wget https://nginx.org/download/nginx-1.27.0.tar.gz
    tar -xf nginx-1.27.0.tar.gz
    ```

2. Clone `ngx_brotli`, and follow the steps listed in the first "Statically compiled" section of the repository.

    ```bash
    git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
    cd ngx_brotli/deps/brotli
    mkdir out && cd out
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
    cmake --build . --config Release --target brotlienc
    cd ../../../..
    ```

    If updating the cloned repository, run `git pull --recruse-submodules` instead.

3. Switch to the `nginx` directory and run the "Dynamically loaded" steps, taking care to ensure the compilation output from `nginx -V` is included when running `./configure`.

    ```bash
    cd nginx-1.27.0
    ./configure --with-compat --add-dynamic-module=/path/to/ngx_brotli
    ```

4. Move the compiled module files:

    ```bash
    mv objs/*.so /usr/lib/nginx/modules
    ```

5. Add `load_module` directives to `nginx.conf`.
    This will already have been completed if you updating `nginx` via a package manager.

    ```nginx
    load_module modules/ngx_http_brotli_filter_module.so;
    load_module modules/ngx_http_brotli_static_module.so;
    ```

This process must be repeated whenever `nginx` is updated via package manager as this will introduce a version mismatch between `nginx` and the `ngx_brotli` module.

## Addendums

If you are dealing with PGP key issues with Nginx's package repositories:

* [Updating the PGP Key for NGINX Software][3]
* [Ubuntu installation guide][4]

[1]: https://github.com/google/ngx_brotli
[2]: https://github.com/google/ngx_brotli?tab=readme-ov-file#installation
[3]: https://blog.nginx.org/blog/updating-pgp-key-for-nginx-software
[4]: https://nginx.org/en/linux_packages.html#Ubuntu
