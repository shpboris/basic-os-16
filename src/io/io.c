#include <io.h>
#include <string.h>


unsigned char drive_number; 

typedef struct  {
	unsigned char drive_number;
	int number_of_heads;
	int sectors_per_track;	
	char drive_type;	
	unsigned char number_of_drives;	 
} DiskGeometry;


typedef struct  {
	char cylinder;
	char head;
	char sector;
	char drive;
} CHS;

void get_disk_geometry(DiskGeometry *disk_geometry_ptr);
void lba_to_chs(DiskGeometry *disk_geometry_ptr, int lba, CHS *chs);

//saves boot device drive number that is put by BIOS into DL register
//all IO operations against disk will use this number of drive
//when booting from USB on real hardware, hard drive emulation is usually done - so disk number is 0x80
//for floppy emulation disk number is 0x0
void init_io(){
	asm {
		mov [drive_number], dl		
	}
}

//reads sectors to memory
//based on LBA linear address and disk geometry figures out CHS
//and then reads num_sectors from CHS to targ_segm/targ_offset
void read(int lba, char num_sectors, int targ_segm, int targ_offset){
	
	char drive; 
	char cylinder;
	char head;
	char start_sector;
	
	
	CHS chs;
	CHS *chs_ptr = &chs;
	DiskGeometry disk_geometry;
	DiskGeometry *disk_geometry_ptr = &disk_geometry;
	
	
	get_disk_geometry(disk_geometry_ptr);
	lba_to_chs(disk_geometry_ptr, lba, chs_ptr);
	cylinder = chs_ptr->cylinder;
	start_sector = chs_ptr->sector;
	head = chs_ptr->head;
	drive = chs_ptr->drive;	
	
	asm {
		mov  ah,0x02 // read sectors from drive service
		mov  al,[num_sectors]
		mov	 ch,[cylinder] 
		mov  cl,[start_sector]
		mov  dh,[head] 
		mov  dl,[drive] 
		mov  bx, [targ_segm] 
		mov es, bx   
		mov bx, [targ_offset]  
		int  13h // call BIOS to read sectors
	}	
}

//gets disk geometry
void get_disk_geometry(DiskGeometry *disk_geometry_ptr){
	
	char drive_type;
	int sectors_per_track;
	unsigned  char number_of_drives;
	unsigned char max_head;
	int number_of_heads;  
	
	asm {
		push ax
		push cx
		push dx
		push es
		mov dl, [drive_number]
		mov ah, 8
		int 13h                       
		mov [drive_type], bl
		and cx, 3Fh                   
		mov [sectors_per_track], cx
		mov [number_of_drives], dl
		mov [max_head], dh
		pop es
		pop dx
		pop cx
		pop ax
		
	}
	number_of_heads = max_head;
	number_of_heads = number_of_heads + 1;
	
	disk_geometry_ptr->drive_number = drive_number;
	disk_geometry_ptr->sectors_per_track = sectors_per_track;
	disk_geometry_ptr->number_of_heads = number_of_heads;

}



//converts LBA to CHS
void lba_to_chs(DiskGeometry *disk_geometry_ptr, int lba, CHS *chs){	
	chs->sector   = (lba % disk_geometry_ptr->sectors_per_track) + 1;
	chs->cylinder = (lba / disk_geometry_ptr->sectors_per_track) / disk_geometry_ptr->number_of_heads;
	chs->head     = (lba / disk_geometry_ptr->sectors_per_track) % disk_geometry_ptr->number_of_heads;
	chs->drive = disk_geometry_ptr->drive_number;
}

//function to get a character - relies on BIOS interrupt 16h
char getchar() {
	char temp;
	asm {
		mov ah,00h  //00h is a service to read a new character 
		int 16h		//call interrupt with service 00h
		mov [temp],al  //move new character from al register to temp variable
	}
	return temp;
}

//function to print a character - relies on BIOS interrupt 10h
void putchar(char in) {
	char temp = in;
	asm {
		  mov ah,0Eh //0Eh is a service for printing the character
		  mov al,[temp] //printing interrupt handler expects the parameter in al register
		  int 10h  //call interrupt with service 0Eh
	}
}

