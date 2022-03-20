# codebuild-conditional
This is a test repo for triggering codebuild conditionally by comments in PR

Buildspec for codebuild uses [build_extras.sh](./aws_buildspecs/build_extras.sh)

Build extras bash file sets environement variables those can be used as condition in buildspec file.

Script sets all build variables to true by default, for direct merges. If you do not allow direct merges then those variables by default should be set to false.