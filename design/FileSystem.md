@startuml

!define ROOT_PACKAGE_NAME FileSystem

package "文件系统" as fs {

    class EasyFileSystem{
        +block_device: BlockDevice
        +inode_bitmap: Bitmap
        +data_bitmap: Bitmap
        -inode_area_start_block: u32
        -data_area_start_block: u32
    }

    class Bitmap {
        -start_block_id: usize "The absolute block index in disk."
        -blocks: usize  "The number of bitmap occupying."
    }


    class DiskInode {
        +size: u32,
        +direct: [u32; INODE_DIRECT_COUNT],
        +indirect1: u32,
        +indirect2: u32,
        -type_: DiskInodeType,
        +nlink: u32,
    }

    class Inode {
        -block_id: usize,
        -block_offset: usize,
        -fs: Arc<Mutex<EasyFileSystem>>,
        -block_device: Arc<dyn BlockDevice>,
    }
    

    interface BlockDevice {
        +write_block()
        +read_block()
        +handle_irq()
    }

    class OSInode {
        -readable: bool
        -writable: bool
        -inner: UPIntrFreeCell<OSInodeInner>
    }

    class OSInodeInner{
        offset: usize,
        inode: Arc<Inode>,
    }

    class File {}

    Inode *-- EasyFileSystem: A Inode contains a reference of EasyFileSystem.
    EasyFileSystem *-- Bitmap
    Inode *-- BlockDevice
    OSInode *-- OSInodeInner
    OSInodeInner *-- Inode
    File *-- OSInode

    Inode .. DiskInode : The block_id is the block index of DiskInode in disk.
    Inode .. DiskInode : The block_offset is offset of the block.
}

@enduml
