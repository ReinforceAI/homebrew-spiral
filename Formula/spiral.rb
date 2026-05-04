class Spiral < Formula
  desc "Run 7B coding models on Mac with 200K+ token context via physics-derived compression"
  homepage "https://github.com/ReinforceAI/spiral"
  url "https://github.com/ReinforceAI/spiral/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "c2b033771df473e7ea51c0da6d090c8d252438d5c229b3772fa69da1a8baadeb"
  license "MIT"

  depends_on "cmake" => :build
  depends_on :macos

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DCMAKE_BUILD_TYPE=Release",
           "-DGGML_METAL=ON",
           "-DLLAMA_CURL=OFF",
           "-DBUILD_SHARED_LIBS=ON",
           *std_cmake_args
    system "cmake", "--build", "build", "--config", "Release"

    # All dylibs are built into build/bin/ alongside the executables
    bin.install "build/bin/llama-cli"
    bin.install "build/bin/llama-server"
    bin.install "build/bin/llama-simple"

    # Install shared libraries from build/bin/
    lib.install Dir["build/bin/lib*.dylib"]

    # Fix rpaths so binaries find the libs
    %w[llama-cli llama-server llama-simple].each do |b|
      system "install_name_tool", "-add_rpath", lib.to_s, bin/b
    end

    # Install Spiral wrapper scripts
    bin.install "bin/spiral-chat"
    bin.install "bin/spiral-serve"
    bin.install "bin/spiral-download"
  end

  def post_install
    (var/"spiral/models").mkpath
  end

  def caveats
    <<~EOS
      Spiral has been installed. On first run, the model will be
      downloaded automatically (~4.7 GB).

      Quick start:
        spiral-chat                     # interactive chat
        spiral-serve                    # API server on port 8080
        spiral-chat --prompt "hello"    # single prompt

      Models are stored in ~/.spiral/models/

      For more info: spiral-chat --help
    EOS
  end

  test do
    assert_match "spiral", shell_output("#{bin}/spiral-chat --help 2>&1")
    assert_match "spiral", shell_output("#{bin}/spiral-serve --help 2>&1")
    assert_match "spiral", shell_output("#{bin}/spiral-download --help 2>&1")
  end
end