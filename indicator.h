#ifndef INDICATOR_H
#define INDICATOR_H

#include <time.h>

typedef struct Indicator {
    time_t timestamp;
    int volume;
    double low;
    double high;
    double open;
    double close;
} Indicator;

#endif
