ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS builder

RUN apk add --no-cache gcc make musl-dev git \
	&& git clone --recurse-submodules https://github.com/kaisereagle/cint.git
WORKDIR /cint

ENV CINTSYSDIR = /cint
ENV PATH="$CINTSYSDIR:${PATH}"
ENV LD_LIBRARY_PATH="$CINTSYSDIR:${LD_LIBRARY_PATH}"
ENV LD_ELF_LIBRARY_PATH="$CINTSYSDIR:${LD_ELF_LIBRARY_PATH}"
RUN apk add --no-cache readline-dev g++
RUN git checkout 2c1d9d8ac47c8a36a545063a56962c53535b029c


RUN cd platform && sh clean_bin.sh
RUN sh ./setup platform/linux_RH_64_so

ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apk add --no-cache musl-dev make

COPY --from=builder /cint /cint

ENV CINTSYSDIR = /cint
ENV PATH="$CINTSYSDIR:${PATH}"
ENV LD_LIBRARY_PATH="$CINTSYSDIR:${LD_LIBRARY_PATH}"
ENV LD_ELF_LIBRARY_PATH="$CINTSYSDIR:${LD_ELF_LIBRARY_PATH}"

ENV CC=/cint
WORKDIR /usr/src/myapp

CMD ["cint", "-h"]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/cint" \
	  org.label-schema.description="build cint compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-cint" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/cint -f Dockerfile ."
