#include <vlc.h>

libvlc_instance_t* vlc_instance;
//const char NAME[] = "Player";
const char* pNAME = "Player";

int main(void){

    vlc_instance = libvlc_new(0, NULL);

    libvlc_add_intf( vlc_instance, pNAME );
    
    

    return 0;
}