function dockerbuild() 
{
    local image=go182-centos-7
    local goCache=~/.cross-go-cache

    if test -z "$(docker images | grep ${image})"; then
        echo "正在为你安装编译环境..."
        docker build -t ${image} .
    fi

    echo cross build

    docker run \
        --rm \
        --workdir=/app/ \
        -it \
        -v $(pwd):/app \
        -v ${goCache}/${image}/pkg:/root/go/ \
        -v ${goCache}/${image}/build:/root/.cache/go-build \
        ${image} \
        go build 
}
dockerbuild