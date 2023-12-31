#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/signal.h>
#include <fcntl.h>
#include <termios.h>
#include <bits/stdc++.h>

using namespace std;

#define MPU_NOTIFYLOGIN      (const char*)"2\n"
#define MPU_REQSCREENSHOT    (const char*)"#1\r\n"
#define MPU_CORMFIRM         (const char*)"1\n"
#define MPU_OUTOFPAPPER      (const char*)"#2\r\n"
#define MPU_PAPERJAM         (const char*)"#3\r\n"
#define MPU_WEBTIMEOUT       (const char*)"#0\n"

int main() {
    printf("ABC\r\n");
    struct termios options;

	int fd = open("/dev/ttyUSB1", O_RDWR | O_NOCTTY | O_NDELAY);
	if (fd < 0) {
		printf("Can't open \'/dev/ttyUSB1\'\r\n");
		exit(EXIT_FAILURE);
	}
	else {
		fcntl(fd, F_SETFL, 0);

		/* get current status */
		tcgetattr(fd, &options);

		cfsetispeed(&options, B115200);
		cfsetospeed(&options, B115200);

		/* No parity (8N1) */
		options.c_cflag &= ~PARENB;
		options.c_cflag &= ~CSTOPB;
		options.c_cflag &= ~CSIZE;
		options.c_cflag |= CS8;

		options.c_cflag |= (CLOCAL | CREAD);
		options.c_cflag     &=  ~CRTSCTS;

		cfmakeraw(&options);

		tcflush(fd, TCIFLUSH);
		if (tcsetattr (fd, TCSANOW, &options) != 0) {
			printf("error in tcsetattr()\n");
		}
    }

	uint8_t buf[32];
	uint32_t len;
	string IncomMsg = "";

	write(fd, MPU_NOTIFYLOGIN, strlen(MPU_NOTIFYLOGIN));

	while (1) {
		memset(buf, 0, 32);
		len = read(fd, buf, 32);
		if (len != -1) {
			for (uint8_t id = 0; id < len; ++id) {
				IncomMsg += buf[id];
				printf("[DATA] %d\r\n", buf[id]);
			}
			if (IncomMsg.compare(string(MPU_REQSCREENSHOT)) == 0) {
				usleep(1000000);
				printf("[CORMFIRM] Message: %s\r\n", IncomMsg.c_str());
				int ret = write(fd, MPU_CORMFIRM, strlen(MPU_CORMFIRM));
				IncomMsg.clear();
			}
			else if (IncomMsg.compare(string(MPU_OUTOFPAPPER)) == 0) {
				printf("[OUTOFPAPPER] Message: %s\r\n", IncomMsg.c_str());
				IncomMsg.clear();
			}
			else if (IncomMsg.compare(string(MPU_PAPERJAM)) == 0) {
				printf("[PAPERJAM] Message: %s\r\n", IncomMsg.c_str());
				IncomMsg.clear();
			}
			else if (IncomMsg.compare(string("Hello world\r\n")) == 0) {
				printf("Message: %s\r\n", IncomMsg.c_str());
				int ret = write(fd, MPU_CORMFIRM, strlen(MPU_CORMFIRM));
				IncomMsg.clear();
			}
		}
	}

    return 0;
}

