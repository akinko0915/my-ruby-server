require "socket"

# https://docs.ruby-lang.org/ja/latest/class/TCPServer.html
gs = TCPServer.open(0);
addr = gs.addr
addr.shift
printf("server is on %s\n", addr.join(":"))

while true
    # https://docs.ruby-lang.org/ja/latest/class/Thread.html
    Thread.start(gs.accept) do |s|
        print(s, " is accepted\n")
        while s.gets
            s.write($_)
        end
        print(s, " is gone\n")
        s.close
    end
end