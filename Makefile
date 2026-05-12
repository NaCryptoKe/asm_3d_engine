ASM     = nasm
AFLAGS  = -f elf64 -g -F dwarf
LD      = ld
LFLAGS  = -dynamic-linker /lib64/ld-linux-x86-64.so.2 \
          -lX11 \
          -rpath /usr/lib \
          -L/usr/lib

SRCDIR  = src
OBJDIR  = build
TARGET  = build/game

SRCS    = $(SRCDIR)/main.asm \
          $(SRCDIR)/x11.asm \
          $(SRCDIR)/renderer.asm \
          $(SRCDIR)/player.asm \
          $(SRCDIR)/map.asm \
          $(SRCDIR)/math.asm

OBJS    = $(patsubst $(SRCDIR)/%.asm, $(OBJDIR)/%.o, $(SRCS))

.PHONY: all clean run

all: $(OBJDIR) $(TARGET)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: $(SRCDIR)/%.asm
	$(ASM) $(AFLAGS) -o $@ $<

$(TARGET): $(OBJS)
	$(LD) $(LFLAGS) -o $@ $^

run: all
	./$(TARGET)

clean:
	rm -rf $(OBJDIR)
