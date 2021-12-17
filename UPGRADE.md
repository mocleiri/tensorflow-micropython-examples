# Upgrading building from scratch to latest

The main item needed is to get the 3 submodules updated to the latest code.

Espescially the current tensorflow directory which has been repointed at my fork until 
[tflite-micro#704](https://github.com/tensorflow/tflite-micro/pull/704) has been merged.

Tensorflow uses *.cc for c++ files while Micropython expects them to be suffixed with *.cpp.

The above pull request is upstreaming the --rename-cc-to-cpp switch and is almost complete.

# Upgrade submodules

```shell
$ git submodule update

```

This should trigger an update to the tensorflow, micropython and micropython-ulab submodules.

But tensorflow and micropython have their own submodules.

```shell
$ cd micropython
$ git submodule update
$ cd ../tensorflow
$ git submodule update
```

You can verify that this worked by looking at the log of what is at the tip of the checked out branch for each
and that the commit date is in December 2021. 