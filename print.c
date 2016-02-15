#include "print.h"

void Print_data(Quotes *quotes) {
    const char color_red[] = "\x1B[31m";
    const char color_green[] = "\x1B[32m";
    const char color_reset[] = "\033[0m";

    printf("Symbol: %s\n", quotes->symbol);
    printf("Currency: %s\n", quotes->currency);
    printf("Size: %zu\n", quotes->size);

    char subtitle[] = "| OPEN | HIGH | LOW  | CLOSE|";
    printf("%s\n", subtitle);

    for (int i = 0; i < (int)quotes->size; i++) {
        if (quotes->indicators[i].open != 0) {
            char color[10];
            if (quotes->indicators[i].open > quotes->indicators[i].close) {
                strcpy(color, color_red);
            } else {
                strcpy(color, color_green);
            }

            printf("%s|%.4f|%.4f|%.4f|%.4f|%s %s",
                    color,
                    quotes->indicators[i].open,
                    quotes->indicators[i].high,
                    quotes->indicators[i].low,
                    quotes->indicators[i].close,
                    color_reset,
                    ctime(&quotes->indicators[i].timestamp)
                  );
        }
    }

    printf("%s\n", subtitle);
}
