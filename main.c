#include <stdio.h>
#include <string.h>
#include <time.h>

#include "quotes.h"
#include "request.h"
#include "print.h"


int main() {
    char url[] = "https://finance-yql.media.yahoo.com/v7/finance/chart/USDBRL=X?period1=1454583600&period2=1454616300&interval=1m";

    char *response_data = Request_get(url);
    Quotes *quotes = Quotes_create(response_data);

    Print_data(quotes);

    Quotes_cleanup(quotes);

    return 0;
}
