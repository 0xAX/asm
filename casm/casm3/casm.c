#include <string.h>

extern void printHelloWorld(char *str, int len);

int main() {
	char* str = "Hello World\n";
	int len = strlen(str);
	printHelloWorld(str, len);
	return 0;
}
