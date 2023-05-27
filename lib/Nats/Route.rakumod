use Nats;
unit class Nats::Route;

has @.routes;

sub message is export {
    $*MESSAGE
}

sub subscribe(&block) is export {
    my $sig    = &block.signature;
    my @params = $sig.params;

    my @subjects = (
        [X] &block.signature.params.map({
            .slurpy
            ?? (">",)
            !! .constraint_list || ("*",)
        })
    ).map: *.join: ".";

    @*ROUTES.append: do for @subjects -> $subject {
        -> Nats $nats {
            my $sub = $nats.subscribe: $subject;
            $sub.supply.tap: -> $*MESSAGE {
                block |$*MESSAGE.subject.split(".")
            }
        }
    }
}

sub route(&block) is export {
    my @*ROUTES;
    block;
    Nats::Route.new: :routes(@*ROUTES)
}