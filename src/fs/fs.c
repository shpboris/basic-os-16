#include <fs.h>
#include <string.h>
#include <io-api.h>

#define FS_MAP_SIZE_BYTES 512
#define MAX_ENTRIES 30
#define ENTRY_NAME_SIZE 10

#define FS_MAP_SECTOR 0x23
#define FS_MAP_SIZE 0x1
#define SHELL_SECTOR 0x24
#define SHELL_SIZE 0x12
#define FS_MAP_SEGM 0x1000

#define NULL 0 

typedef struct  {
	char  name[ENTRY_NAME_SIZE];
	int   sector;
	char  size;
} FsEntry;

//holds raw FS definition that is read from sector #36
char fs_map[FS_MAP_SIZE_BYTES]; 
int CURR_FS_ENTRIES = 0;
FsEntry fs_entries[MAX_ENTRIES];
FsEntry shell_entry;
FsEntry fs_map_entry;

void load_fs_map();
void populate_fs_sys_entries();
void populate_fs_entries();
int populate_single_entry(char *start, FsEntry *entry);
FsEntry *locate_fs_entry(char *name);
void print_entry();


//central method to initiate FS activities
//reads raw FS definition from sector #36 to fs_map
//parses it and populates fs_entries array so programs locations and sizes on disk becomes known to FS
//also populates location and size for special system programs/data - for fs_map raw data itself and shell
void init_fs() {
	kprintstr("started fs init...");
	kprintstr("\r\n");
	
	populate_fs_sys_entries();	
	load_fs_map();
	populate_fs_entries();
	
	kprintstr("finished fs init...");
	kprintstr("\r\n");	
}


//central function that is offered to external modules (kernel) for loading
//programs to memory by program name and segm/offset memory location
//locates program size and location in FS data structures and uses kread kernel 
//API from io-api.c to actually read from disk
int load(char *params, int targ_segm, int targ_offset){
	int res = 0;
	char lba;
	char num_sectors;
	
	FsEntry *fs_entry = locate_fs_entry(params);
  
	if(fs_entry != NULL){
		lba = fs_entry->sector;
		num_sectors = fs_entry->size;
		kread(lba, num_sectors, targ_segm, targ_offset);
		res = 1;
	}	
	
	return res;
}

//loads raw FS data
void load_fs_map() {
	char * fs_map_ptr = fs_map;
	int segm = FS_MAP_SEGM;
	int offset = fs_map_ptr;
	
	load("fs_map", segm, offset);
	fs_map[FS_MAP_SIZE_BYTES - 1] = '\0';
}

//parses raw FS data
void populate_fs_entries(){
	int i = 0;
	char * start = fs_map + 1;
	while(start != NULL){
		start = populate_single_entry(start, &fs_entries[i]);
		i++;
	}
	CURR_FS_ENTRIES = i;
}

//adds some predefined system locations to FS
void populate_fs_sys_entries(){
	FsEntry *shell_entry_ptr = &shell_entry;
	FsEntry *fs_map_entry_ptr = &fs_map_entry;
	
	shell_entry_ptr->sector = SHELL_SECTOR;
	shell_entry_ptr->size = SHELL_SIZE;
	
	fs_map_entry_ptr->sector = FS_MAP_SECTOR;
	fs_map_entry_ptr->size = FS_MAP_SIZE;	
}

//locates FS entry for specific program
FsEntry *locate_fs_entry(char *name){
	FsEntry *curr = NULL;
	FsEntry *res = NULL;
	int i = 0;
	if(strcmp("sys_shell",name) == 0){
		res = &shell_entry;
	}
	else if(strcmp("fs_map",name) == 0){
		res = &fs_map_entry;
	}
	else{
		for(i = 0; i < CURR_FS_ENTRIES; i++){
			
			curr = &fs_entries[i];
			if(strcmp(curr->name,name) == 0){
				res = curr;
			}
		}
	}
	return res;
}


//low level parsing for single raw FS entry
int populate_single_entry(char *start, FsEntry *entry){
	char *end = NULL;
	char buff[ENTRY_NAME_SIZE];
	int i;
	
	//name
	for(i = 0; i < ENTRY_NAME_SIZE; i++){
		if(start[i] == ':'){
			break;
		}
	}
	memcpy(entry->name, start, i);
	entry->name[i] = '\0';
	
	//sector
	start = start + i + 1;
	for(i = 0; i < ENTRY_NAME_SIZE; i++){
		if(start[i] == ':'){
			break;
		}
	}
	memcpy(buff, start, i);
	buff[i] = '\0';	
	entry->sector = atoi(buff);
	
	//size
	start = start + i + 1;
	for(i = 0; i < ENTRY_NAME_SIZE; i++){
		if(start[i] == '/'){
			end = start + i + 1;
			break;
		}
		else if(start[i] == ']'){
			break;
		}
	}
	memcpy(buff, start, i);
	buff[i] = '\0';
	entry->size = atoi(buff);
	
	return end;
}



//API to get list of files - offered to external modules
void list_files(char *buff){
	FsEntry *curr;
	char tmp[ENTRY_NAME_SIZE];
	int i = 0;
	char *start = buff;

	for(i = 0; i < CURR_FS_ENTRIES; i++){
		curr = &fs_entries[i];
		memcpy(start, curr->name, strlen(curr->name));
		if(i == CURR_FS_ENTRIES - 1){
			*(start + strlen(curr->name)) = '\0';
		}
		else{
			*(start + strlen(curr->name)) = ' ';
		}
		start = start + strlen(curr->name) + 1;
	}
}



void print_entry(FsEntry *curr){
		kprintstr("name: ");
		kprintstr(curr->name);
		kprintstr("\r\n");
		kprintstr("sector: ");
		kprintstr(itoa(curr->sector));
		kprintstr("\r\n");
		kprintstr("size: ");
		kprintstr(itoa(curr->size));
		kprintstr("\r\n");
}




