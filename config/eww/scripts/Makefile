WAYLAND_SCANNER=$(shell pkg-config --variable=wayland_scanner wayland-scanner)

protocols/wlr-output-management-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) client-header \
		protocols/wlr-output-management-unstable-v1.xml $@

protocols/wlr-output-management-unstable-v1-protocol.c:
	$(WAYLAND_SCANNER) private-code \
		protocols/wlr-output-management-unstable-v1.xml $@

protocols/wlr-output-management-unstable-v1-protocol.o: protocols/wlr-output-management-unstable-v1-protocol.h

protocols: protocols/wlr-output-management-unstable-v1-protocol.o

hyprland:
	gcc `pkg-config --cflags jsoncpp`