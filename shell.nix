{ pkgs ? import <nixpkgs> {} }: with pkgs; let

	gems = bundlerEnv {
		ruby = ruby_3_4;
		name = "charwasp-skin-gems";
		gemdir = ./.;
	};

	fonts = stdenvNoCC.mkDerivation {
		name = "charwasp-skin-fonts";
		src = ./font;
		installPhase = ''
			runHook preInstall
			install -Dm644 *.otf -t $out/share/fonts/otf
			runHook postInstall
		'';
	};

in mkShell {
	packages = [
		scour
		inkscape
		fonts
		gems
		gems.wrappedRuby
	];
}
