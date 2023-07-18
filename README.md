# docker-linuxqq

Docker builds scripts for Linux QQNT

## Usage

### Pull from GitHub Packages

```bash
docker pull ghcr.io/mnixry/docker-linuxqq:main
```

### Run

```bash
docker run --rm --name qqnt \
    -e VNC_PASSWORD=12345678 \ # VNC Password, max 8 characters, unset to disable password
    -p 8083:8083 \ # noVNC port, access via browser
    ghcr.io/mnixry/docker-linuxqq:main
```

## TODO

- [ ] Add persistent storage support
- [ ] Extensible modding support
- [ ] Continuous integration with automated update support
- [ ] Publish to Docker Hub

## License

This project is licensed under GPLv3.

## Acknowledgments

- [docker-novnc](https://github.com/oott123/docker-novnc/)
- [arch-novnc](https://github.com/ponsfrilus/arch-novnc/)
