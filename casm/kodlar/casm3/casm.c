#include <string.h>

extern void merhabaDunyaYazdir(char *str, int len);

int main() {
	char* str = "Merhaba Dunya\n";
	int len = strlen(str);
	merhabaDunyaYazdir(str, len);
	return 0;
}
