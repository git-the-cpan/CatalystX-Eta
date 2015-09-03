package CatalystX::Eta::Controller::AutoResultPUT;

use Moose::Role;
requires 'result_PUT';

around result_PUT => \&AutoResult_around_result_PUT;

sub AutoResult_around_result_PUT {
    my $orig = shift;
    my $self = shift;
    my ($c)  = @_;

    my $something = $c->stash->{ $self->config->{object_key} };

    my $data_from = $self->config->{data_from_body} ? 'data' : 'params';

    my $params = { %{ $c->req->$data_from } };
    if ( exists $self->config->{prepare_params_for_update}
        && ref $self->config->{prepare_params_for_update} eq 'CODE' ) {
        $params = $self->config->{prepare_params_for_update}->( $self, $c, $params );
    }

    $something->execute(
        $c,
        for => ( exists $c->stash->{result_put_for} ? $c->stash->{result_put_for} : 'update' ),
        with => $params,
    );

    $self->status_accepted(
        $c,
        location => $c->uri_for( $self->action_for('result'), [ @{ $c->req->captures } ] )->as_string,
        entity => { id => $something->id }
    ) if $something;

    $self->$orig(@_);

}

1;
