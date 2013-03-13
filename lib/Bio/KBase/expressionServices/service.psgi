use ExpressionServicesImpl;

use ExpressionServicesServer;



my @dispatch;

{
    my $obj = ExpressionServicesImpl->new;
    push(@dispatch, 'ExpressionServices' => $obj);
}


my $server = ExpressionServicesServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler;
