#include "TemplateLibrary/TemplateLibrary.h"
#include <ctime>
#include <thread>


int main(int argc, char** argv) {
  
    TemplateLibrary myTemplateLibrary;

    spdlog::info("App has default logger");
    myTemplateLibrary.run();

    spdlog::info("App disabled logger");
    myTemplateLibrary.disableLogger();
    myTemplateLibrary.run();


    spdlog::info("App re-enable default logger");
    myTemplateLibrary.enableLogger();
    myTemplateLibrary.run();


    return 0;
}

