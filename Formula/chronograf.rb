require "language/node"

class Chronograf < Formula
  desc "Open source monitoring and visualization UI for the TICK stack"
  homepage "https://docs.influxdata.com/chronograf/latest/"
  url "https://github.com/influxdata/chronograf/archive/1.7.17.tar.gz"
  sha256 "dd5e3e29f3df793cb5325c5e68e1bfcef0db90f34c212aec23068fafa0a553d8"
  head "https://github.com/influxdata/chronograf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "ff48c1fab582d47da2b6d582b4801ae59d142b8a546bd08d426399a9a194c154" => :catalina
    sha256 "a8589305d3cf1ac1d2e9adbd7f03bd35bd3999f06ceee202cbebf5a0c8672755" => :mojave
    sha256 "9f04d3c4fa7e7e46f99fbae2ffef55304d7256c297a07045e0269d64256d2264" => :high_sierra
  end

  depends_on "go" => :build
  depends_on "go-bindata" => :build
  depends_on "node" => :build
  depends_on "yarn" => :build
  depends_on "influxdb"
  depends_on "kapacitor"

  def install
    ENV["GOPATH"] = buildpath
    ENV.prepend_create_path "PATH", buildpath/"bin"
    Language::Node.setup_npm_environment
    chronograf_path = buildpath/"src/github.com/influxdata/chronograf"
    chronograf_path.install buildpath.children

    cd chronograf_path do
      cd "ui" do # fix node 12 compatibility
        system "yarn", "upgrade", "parcel@1.11.0", "node-sass@4.12.0"
      end
      system "make", "dep"
      system "make", ".jssrc"
      system "make", "chronograf"
      bin.install "chronograf"
      prefix.install_metafiles
    end
  end

  plist_options :manual => "chronograf"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/chronograf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/chronograf.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/chronograf.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    pid = fork do
      exec "#{bin}/chronograf"
    end
    sleep 10
    output = shell_output("curl -s 0.0.0.0:8888/chronograf/v1/")
    sleep 1
    assert_match %r{/chronograf/v1/layouts}, output
  ensure
    Process.kill("SIGINT", pid)
    Process.wait(pid)
  end
end
