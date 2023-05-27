use Nats;
unit class Nats::Server;

has Str() @.servers = "nats://127.0.0.1:4222";
has Nats  $.nats    = Nats.new: :servers(@!servers);
has       $.application is required;

method start {
    await $!nats.start;

    for $!application.routes -> &route {
        route $!nats
    }
}

method stop {
    $!nats.stop;
}