FROM fuzzers/afl:2.52 as builder

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libsdl2-dev
ADD . /ggwave
WORKDIR /ggwave
RUN git submodule init
RUN git submodule update
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ .
RUN make
RUN make install
RUN wget https://www2.cs.uic.edu/~i101/SoundFiles/preamble10.wav
RUN wget https://www2.cs.uic.edu/~i101/SoundFiles/StarWars3.wav
RUN wget https://www2.cs.uic.edu/~i101/SoundFiles/taunt.wav

FROM fuzzers/afl:2.52
COPY --from=builder /ggwave/bin/ggwave-from-file /
COPY --from=builder /ggwave/*.wav /testsuite/
# Copy ggwave shared objects and find them
COPY --from=builder /usr/local/lib/* /usr/local/lib/
ENV LD_LIBRARY_PATH=/usr/local/lib/

ENTRYPOINT ["afl-fuzz", "-t", "3000+", "-i", "/testsuite", "-o", "/ggwaveOut"]
CMD  ["/ggwave-from-file", "@@"]
