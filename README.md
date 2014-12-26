<h1>Image-Resizer</h1>

A Perl script for quickly making thumbnails and other sizes for blog posts

<h2>Usage</h2>

Run the following command to create sizes of an image:

```
perl resize.pl [image] [sizes] [directory]

e.g.
perl resize.pl modularity.jpg sizes.json
```

This produces images in the following format:

```
[directory]/[image]-[size].jpg
```

If `directory` is left blank, the resulting files will be placed in the same directory as the specified image.

The `sizes` file should be in JSON format:

```json
{
    "thumbnail": {
        "width": 220,
        "height": 220,
        "crop": 1,
        "quality": 85
    },
    "medium": {
        "width": 800,
        "height": 550,
        "crop": 0,
        "quality": 90
    },
    "large": {
        "width": 1200,
        "height": 800,
        "crop": 0,
        "quality": 90
    }
}
```

If `crop` is specified and set to 1, parts of the image will be cropped so that the image fits exactly the specified size. Otherwise, images will be scaled so that the image does not exceed the specified width or height.
