# Run Zimbra in Docker

This is Zimbra all-in-one in docker. Multiserver is in the plan.

# Basic stuffs

The build has `Dockerfile`. It creates the images and we push it to Docker Hub for mass deployment.

The `compose.yml` coordinate the running of Zimbra in production. It attaches the data volume to the container and start it.

When container is running, the `entrypoint.sh` will "glue" the data and do the necessary works to start the Zimbra up.

By doing so we can always push new updated images and consumers pull to enjoy the new updates.

Many more enhancements can be made to add customizations into the images so that every updates will maintain or reapply the customizations.

# Build

The `build` folder consists of `build.sh` script. Run it to make a new images.

```
$ build/build.sh
```
Check the image is created.

```
$ docker images
```

You can edit the build.sh to change the tag to your preference.

# Run it first time

When run it first time, the container will configure the Zimbra using information from compose.yml. This will take some times to complete.

# Run in production

You should be able to run the container in production using this flow.

```
$ docker compose pull
$ docker compose down
$ docker compose up -d
```

# Zimbrenet

The `zimbranet.sh` create a container network and expose the container directly to the host network . This make your container no longer hidden inside the host. Use this with care.
