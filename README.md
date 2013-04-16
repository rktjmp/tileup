Tile Up
=======

*Tile Up* is a ruby Ruby gem that splits a large image into a set of tiles to use with javascript mapping libraries such as [Leaflet.js](http://leafletjs.com) or [Modest Maps](http://modestmaps.com/). You can also use *Tile Up* to make tiles for `CATiledLayer` (or anything else really...).

Installation
------------

`gem install tileup`

`tileup` requires `rmagick` for image manipulation, which depends on `imagemagick`. `imagemagick` is avaliable through `homebrew`.

Usage
-----

### Basics

To generate some tiles from a large image, you'll probably use something like:

```
tileup --in huge_image.png --output-dir image_tiles \
        --prefix my_tiles --verbose
```

Which will split `huge_image.png` up into `256x256` (default) sized tiles, and save them into the directory `image_tiles`. The images will be saved as `my_tiles_[COLUMN]_[ROW].png`

```
image_tiles/my_tiles_0_0.png
image_tiles/my_tiles_0_1.png
image_tiles/my_tiles_0_2.png
...
```

### Auto zooming

`tileup` can also scale your image for a number of zoom levels (max 20 levels). This is done by *scaling down* the original image, so make sure its pretty big.

*(Auto zooming is an experimental hack, it should work fine for smaller increments, but may be unreliable at higher levels. E.g. `--auto-zoom 4` should work fine, `--auto-zoom 20` might not work so well.)*

```
tileup --in really_huge_image.png --auto-zoom 4 \
       --output-dir map_tiles
```

`--auto-zoom 4` means, make 4 levesl of zoom, starting from `really_huge_image.png` at zoom level 20, then scale that down for 19, etc.

You should see something like:

```
map_tiles/20/map_tile_0_0.png
map_tiles/20/map_tile_0_1.png
map_tiles/20/map_tile_0_2.png
...
map_tiles/19/map_tile_0_0.png
map_tiles/19/map_tile_0_1.png
map_tiles/19/map_tile_0_2.png
...
```
*(where `20` is zoom level 20, the largest zoom, `19` is half the size of `20`, `18` is half the size of `19`, …)*


### Getting help

You can get help by running `tileup -h`.

Contributing
------------

Fixes and patches welcome, to contribute:

1. Fork this project
1. Create a feature or fix branch *off the develop branch*
1. Submit a pull request on that branch
