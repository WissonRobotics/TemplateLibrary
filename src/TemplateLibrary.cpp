
#include "TemplateLibrary/TemplateLibrary.h"
#include <stdio.h> 
#include "stdlib.h"
#include <cstring>
#include <vector>
#include <chrono>
#include <fstream>
#include <iostream>
#include <ctime>
#include <iterator> 
#include <filesystem>
#include <spdlog/spdlog.h>
#include <thread>

/************************************* Pimpl**************************************** */
class TemplateLibrary::TemplateLibraryImpl
{

public:
    TemplateLibraryImpl();
 
	void run(){
		m_logger->info("run hahaha = {}", m_hahaha++);
	}
	void enableLogger(std::shared_ptr<spdlog::logger> ext_logger);
	void disableLogger();
	std::shared_ptr<spdlog::logger> m_logger; 

private:
	int m_hahaha=0;

};
 
TemplateLibrary::TemplateLibraryImpl::TemplateLibraryImpl():m_logger(spdlog::default_logger()){

}

void TemplateLibrary::TemplateLibraryImpl::enableLogger(std::shared_ptr<spdlog::logger> ext_logger){
	m_logger = ext_logger;
}
 
void TemplateLibrary::TemplateLibraryImpl::disableLogger(){
    if(spdlog::get("disabledLogger")){
        m_logger = spdlog::get("disabledLogger");
    }
    else{
        m_logger = spdlog::stdout_color_mt("disabledLogger");
    }
    m_logger->set_level(spdlog::level::off);
}
 
 
 


 

/**********************************               ***********************************************/
TemplateLibrary::TemplateLibrary():m_unique_TemplateLibraryImpl(std::make_unique<TemplateLibraryImpl>()){

}
TemplateLibrary::~TemplateLibrary() = default;
TemplateLibrary::TemplateLibrary(TemplateLibrary&& rhs) = default;
TemplateLibrary& TemplateLibrary::operator=(TemplateLibrary&& rhs) = default;
 

void TemplateLibrary::run(){
	m_unique_TemplateLibraryImpl->run();
}

void TemplateLibrary::enableLogger(std::shared_ptr<spdlog::logger> ext_logger){
	m_unique_TemplateLibraryImpl->enableLogger(ext_logger);
}
void TemplateLibrary::disableLogger(){
	m_unique_TemplateLibraryImpl->disableLogger();
}
