#![no_std]
#![no_main]

fn putc(c: u8) {
    const OUT: *mut u32 = 0x1000_0000 as *mut u32;
    unsafe { core::ptr::write_volatile(OUT, c as u32); }
}

fn puts(s: &[u8]) {
    for &c in s {
        putc(c);
    }
    putc(b'\n');
}

#[no_mangle]
extern "C" fn main() {
    puts(b"Hello, world!");
    loop {}
}

#[panic_handler]
fn panic_handler(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
