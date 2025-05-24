{ pkgs ? import <nixpkgs> {} }: with pkgs; mkShell {
	packages = [
		gcc
		inkscape
		scour
		ruby_3_4
	];
	shellHook = ''
		export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:${imagemagick.dev}/lib/pkgconfig
	'';
}
