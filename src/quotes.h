#ifndef QUOTES_H
#define QUOTES_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <cJSON/cJSON.h>

typedef struct Indicator {
    time_t timestamp;
    int volume;
    double low;
    double high;
    double open;
    double close;
} Indicator;

typedef struct Quotes {
    char symbol[12];
    char currency[4];
    Indicator *indicators;
    size_t size;
} Quotes;

void Quotes_add(Quotes *quotes, Indicator indicator);

void Quotes_cleanup(Quotes *quotes);

Quotes* Quotes_create(char *json_string);

#endif
