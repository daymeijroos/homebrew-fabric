class FabricAi < Formula
  desc "fabric is an open-source framework for augmenting humans using AI. It provides a modular framework for solving specific problems using a crowdsourced set of AI prompts that can be used anywhere."
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.157.tar.gz"
  sha256 "e27189c4a77f40e194c83feb33e3a064ac0729f313cbfd92d18e5b43d43d0b6c"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git"

  depends_on "go" => :build

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    ENV["GOPATH"] = buildpath
    path = buildpath/"src/github.com/danielmiessler/fabric"
    system "go", "get", "-u", "github.com/danielmiessler/fabric"
    cd path do
      system "go", "build", "-o", "#{bin}/fabric"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fabric", "-v")
  end
end