require 'fileutils'

task :extract do
	raise 'Dir assets not found' unless Dir.exist? 'assets'

	require 'json'
	require 'plist'
	require 'rmagick'

	Dir.glob 'assets/**/*.plist' do |plist_path|
		image = Magick::ImageList.new plist_path.sub %r{\.plist$}, '.png'
		FileUtils.mkdir_p output_dir = plist_path.sub(%r{^assets/}, 'extract/').sub(%r{/[^/]*\.plist$}, '')
		Plist.parse_xml(plist_path)['frames'].each do |name, info|
			(x, y), (width, height) = JSON.parse info['frame'].tr '{}', '[]'
			image.crop(x, y, width, height).write File.join output_dir, name
		end
	end
end

task :build do
	require 'mkmf'
	raise 'Command scour not found' unless scour = find_executable('scour')
	raise 'Command inkscape not found' unless inkscape = find_executable('inkscape')

	require 'zlib'
	require 'rexml/document'
	require 'rmagick'

	scour_options = %w[--enable-viewboxing --enable-id-stripping --enable-comment-stripping --shorten-ids --indent=none]

	FileUtils.mkdir_p 'tmp'
	tmp_svg = 'tmp/temp.svg'

	Dir.glob 'src/**/*.svg' do |svg_path|
		FileUtils.mkdir_p File.dirname svg_output = svg_path.sub(%r{^src/}, 'build/svg/')
		FileUtils.mkdir_p File.dirname svgz_output = svg_path.sub(%r{^src/}, 'build/svgz/').sub(/\.svg$/, '.svgz')
		FileUtils.mkdir_p File.dirname png_output = svg_path.sub(%r{^src/}, 'build/png/').sub(/\.svg$/, '.png')

		texts = REXML::XPath.each(REXML::Document.new(File.read svg_path), '//text').map { it.attributes&.[] 'id' }.compact.join ','
		if texts.empty?
			system scour, '-i', svg_path, '-o', svg_output, *scour_options
		else
			system inkscape, svg_path, '--actions', "select: #{texts}; object-to-path; export-type: svg; export-filename: #{tmp_svg}; export-do"
			system scour, '-i', tmp_svg, '-o', svg_output, *scour_options
		end

		Zlib::GzipWriter.open(svgz_output) { it.write File.read svg_output }
		Magick::ImageList.new(svg_output) { it.background_color = 'none' }.write png_output
	end
end

task :spritesheet do
	raise 'Dir assets not found' unless Dir.exist? 'assets'
	raise 'Dir build not found' unless Dir.exist? 'build'

	require 'json'
	require 'rmagick'
	require 'plist'

	Dir.glob 'assets/**/*.plist' do |plist_path|
		build_dir = File.dirname plist_path.sub %r{^assets/}, 'build/png/'
		next unless Dir.exist? build_dir
		image_path = plist_path.sub %r{\.plist$}, '.png'
		image, *_ = Magick::Image.read image_path

		FileUtils.mkdir_p File.dirname output_path = image_path.sub(%r{^assets/}, 'spritesheet/')
		Plist.parse_xml(plist_path)['frames'].each do |name, info|
			source_path = File.join build_dir, name
			next unless File.exist? source_path
			(x, y), (width, height) = JSON.parse info['frame'].tr '{}', '[]'
			source, *_ = Magick::Image.read source_path
			#image.composite! source, x, y, Magick::SrcCompositeOp # https://github.com/rmagick/rmagick/issues/1695
			image.import_pixels x, y, width, height, 'RGBA', source.export_pixels_to_str(0, 0, width, height, 'RGBA')
		end
		image.write output_path
	end
end

task :clean do
	FileUtils.rm_r 'build' if Dir.exist? 'build'
	FileUtils.rm_r 'extract' if Dir.exist? 'extract'
	FileUtils.rm_r 'tmp' if Dir.exist? 'tmp'
end

task default: :build
