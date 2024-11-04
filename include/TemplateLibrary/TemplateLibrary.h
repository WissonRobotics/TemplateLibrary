#pragma once
#include "SlimSerialRTDE/SlimSerialRTDE.h"
 

class TemplateLibrary
{

public:
    TemplateLibrary();

    ~TemplateLibrary();

    TemplateLibrary(TemplateLibrary&& rhs);
    TemplateLibrary& operator=(TemplateLibrary&& rhs);

    
    void run();
    void enableLogger(std::shared_ptr<spdlog::logger> ext_logger=spdlog::default_logger());
    void disableLogger();
  
private:
    /* pimpl pattern*/
    class TemplateLibraryImpl; 
 	std::unique_ptr<TemplateLibraryImpl> m_unique_TemplateLibraryImpl;
};
 