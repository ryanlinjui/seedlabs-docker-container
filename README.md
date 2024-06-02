# SEED Labs Docker Container Environment.

Modyfied by [SeedLab Setup](https://github.com/seed-labs/seed-labs/blob/master/manuals/cloud/seedvm-cloud.md)

## Support Tools and Software
- [x] Utilities Tools and Libraries
- [x] Vncserver (TigerVNC)
- [x] Desktop Environment (xfce4)
- [x] Docker
- [x] Wireshark
- [ ] Firefox
- [ ] VSCode
- [ ] bless

## Setup SeedLab Environment with Docker Container

### Build Docker Image

```bash
docker build -t seedlab .
```

### Run in Docker Container
```bash
docker run -it --rm --privileged -p 5901:5901 -v .:/root/Desktop seedlab
```

### You can connect to the VNC server using the following URL:
```
vnc://localhost:5901
```
> Password: `password`, you can change it in the Dockerfile.

### Reference
- [VNC Server in Docker Container](https://medium.com/@gustav0.lewin/how-to-make-a-docker-container-with-vnc-access-f607958141ae)
- [JacobLinCool's Dockerfile](https://github.com/JacobLinCool/ntnu-information-security-2024)
