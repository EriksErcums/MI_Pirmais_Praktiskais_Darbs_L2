# https://godot-build-options-generator.github.io
# https://popcar.bearblog.dev/how-to-minify-godots-build-size/
# scons platform=windows profile=custom.py build_profile=custom.gdbuild

use_mingw="yes"
use_llvm="yes"

target="template_release"
debug_symbols="no"
optimize="size"
lto="full"
tools="no"
#production = "yes"

deprecated="no"
minizip="no"
brotli="no"
openxr="no"
accesskit="no"
graphite="no"

disable_3d="yes"
disable_navigation_2d="yes"
disable_navigation_3d="yes"
disable_xr="yes"

d3d12="no"
vulkan="no"
use_volk="no"
#opengl3="no"

modules_enabled_by_default="no"
module_gdscript_enabled="yes"
#module_text_server_adv_enabled="yes"
module_text_server_fb_enabled="yes" # Default font will look worse
module_freetype_enabled="yes" # To render fonts
module_svg_enabled="yes" # To render default theme elements
#module_raycast_enabled = "yes" # Vulkan NEEDS this
