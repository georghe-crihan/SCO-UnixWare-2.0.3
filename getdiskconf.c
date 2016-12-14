/*
 * Get the disk geometry through the standard ioctl call.
 * Look in /usr/include/sys/vtoc.h for dpt_xxx constants, signifying
 * other disk types. 
 * 
 */
#include <stdio.h>
#include <sys/fcntl.h>
#include <sys/vtoc.h>

static struct disk_parms dp;

int main(int argc, char **argv)
{
int fd;
char *drive = "/dev/rdsk/0s0";

if (argc > 1)
  drive = argv[1];

fd = open(drive, O_RDONLY);
if (fd == -1) {
  perror("open");
  goto done;
  }
if (ioctl(fd, V_GETPARMS, &dp) == -1) {
  perror("ioctl");
  goto done;
  }

printf(
"Type: %s(0x%x)\n"
"Heads: %d\n"
"Cyls: %d\n"
"Sectors/Track: %d\n"
"Bytes/Sector: %d\n"
"Starting Absolute Sector Number: 0x%X\n"
, dp.dp_type == 4 ? "SCSI Hard disk" : "???", 
dp.dp_type,
dp.dp_heads,
dp.dp_cyls,
dp.dp_sectors,
dp.dp_secsiz,
dp.dp_pstartsec
);
done:
close(fd);
return 0;
}
