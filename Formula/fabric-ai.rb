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


class Fabric < Formula
  desc "Fabric CLI: An open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.157.tar.gz"
  sha256 "e27189c4a77f40e194c83feb33e3a064ac0729f313cbfd92d18e5b43d43d0b6c"
  license "MIT"

  head do
    url "https://github.com/danielmiessler/fabric.git", branch: "main"
    depends_on "go@1.14" => :build
  end

  bottle :unneeded

  option "without-completion", "Do not install shell completion"

  depends_on "go@1.14" => :build

  def install
    if build.head?
      ENV["CGO_ENABLED"] = "0"
      ENV["GOGC"] = "off"

      ENV.prepend_create_path "PATH", "#{HOMEBREW_PREFIX}/bin"
      ENV.prepend_create_path "PATH", buildpath/"bin"

      cd buildpath do
        branch = Utils.safe_popen_read("git", "rev-parse", "--abbrev-ref", "HEAD").strip
        package = "#{head.url.delete_prefix("https://").delete_suffix(".git")}/pkg/version"

        binary_version =
          File.readlines("Makefile").grep(/^VERSION.*[0-9.]+/) do |l|
            l.split("=")[1].strip.tr('"', "")
          end[0] += "-#{branch}"

        ldflags = %W[
          -s -w
          -X #{package}.GitBranch=#{branch}
          -X #{package}.GitRevision=#{version.commit}
          -X #{package}.Version=#{binary_version}
        ].join(" ")

        system "go", "build", *std_go_args(ldflags: ldflags)

        unless build.without? "completion"
          output = Utils.safe_popen_read("#{bin}/", "completion", "bash")
          (bash_completion/"").write output

          output = Utils.safe_popen_read("#{bin}/", "completion", "zsh")
          (zsh_completion/"_").write output

          output = Utils.safe_popen_read("#{bin}/", "completion", "fish")
          (fish_completion/".fish").write output
        end
      end
    end

    if OS.mac? && MacOS.version >= :catalina
      if /com.apple.quarantine/.match?(Utils.safe_popen_read("xattr #{bin}/"))
        (bin/"").chmod 0755
        begin
          system "xattr", "-d", "com.apple.quarantine", bin/""
        ensure
          (bin/"").chmod 0555
        end
      end
    end

    prefix.install_metafiles
  end

  def caveats
    <<~EOS
      To install Fabric, ensure Go is installed, then run:
        go install github.com/yourusername/fabric@latest
    EOS
  end

  test do
    assert_predicate bin/"fabric", :exist?
    system bin/"fabric", "--help"
  end
end
