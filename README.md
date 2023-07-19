# docker-linuxqq

Docker builds scripts for Linux QQNT

## Disclaimer

This project is used for educational purposes only. The author of this project is not responsible for any damage caused by the use of this project. You may not use this project for illegal or unethical purposes.

## Usage

```bash
docker run --rm --name qqnt --pull always \
    -e VNC_PASSWORD=12345678 \ # VNC Password, max 8 characters, unset to disable password
    -e USE_SSL=1 \ # use HTTPS protocol for noVNC, unset to use HTTP
    -p 8083:8083 \ # noVNC port, access via browser
    ghcr.io/mnixry/docker-linuxqq:latest
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
- [docker-qqnt](https://github.com/ilharp/docker-qqnt/)
