program_NAME	:=	bin/main
program_CXX_SRCS	:=	$(wildcard src/*.s)
program_CXX_OBJS	:=	${program_CXX_SRCS:.s=.o}
program_OBJS	:=	$(program_CXX_OBJS)
.PHONY: all clean distclean

all: $(program_CXX_OBJS)
	arm-none-eabi-ld $(program_OBJS) -g -o $(program_NAME)

$(program_OBJS): $(program_CXX_SRCS)
	arm-none-eabi-as $(program_CXX_SRCS) -g -o $(program_OBJS)

clean:
	@- $(RM) $(program_NAME)
	@- $(RM) $(program_CXX_OBJS)

test: $(program_NAME)
	qemu-arm $(program_NAME)

distclean: clean
