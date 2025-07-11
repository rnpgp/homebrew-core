class Saxon < Formula
  desc "XSLT and XQuery processor"
  homepage "https://github.com/Saxonica/Saxon-HE"
  url "https://github.com/Saxonica/Saxon-HE/releases/download/SaxonHE12-7/SaxonHE12-7J.zip"
  version "12.7"
  sha256 "f89e2085ac357d9b6cb8a231707aebc5f7f6d0b4ec3a626144ba9656f7592cde"
  license all_of: ["BSD-3-Clause", "MIT", "MPL-2.0"]

  livecheck do
    url :stable
    regex(/^SaxonHE[._-]?v?(\d+(?:[.-]\d+)+)$/i)
    strategy :github_latest do |json, regex|
      match = json["tag_name"]&.match(regex)
      next if match.blank?

      match[1]&.tr("-", ".")
    end
  end

  no_autobump! because: :requires_manual_review

  bottle do
    sha256 cellar: :any_skip_relocation, all: "9c4034c95793e5201c494a6f5306081c90488558205742949d2dea530ff74660"
  end

  depends_on "openjdk"

  def install
    libexec.install Dir["*.jar", "doc", "lib", "notices"]
    bin.write_jar_script libexec/"saxon-he-#{version.major_minor}.jar", "saxon"
  end

  test do
    (testpath/"test.xml").write <<~XML
      <test>It works!</test>
    XML
    (testpath/"test.xsl").write <<~XSL
      <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
        <xsl:template match="/">
          <html>
            <body>
              <p><xsl:value-of select="test"/></p>
            </body>
          </html>
        </xsl:template>
      </xsl:stylesheet>
    XSL
    assert_equal <<~HTML.chop, shell_output("#{bin}/saxon test.xml test.xsl")
      <!DOCTYPE HTML>
      <html>
         <body>
            <p>It works!</p>
         </body>
      </html>
    HTML
  end
end
