package pruebapp;
use Dancer2;
use utf8;
use File::Slurp     qw(read_file write_file);
use POSIX           qw(strftime);

our $VERSION = '0.1';

get '/' => sub {
    my $data_file = config->{pruebapp}{JSON};
    my $json = -e $data_file ? read_file $data_file : '{}';
    my $data = from_json $json;
    template 'index', { data => $data};
};

get '/do' => sub {
    template 'formulario';
};

get '/add' => sub {
    template 'add';
};

get '/page/*' => sub {
    my ($articulo)  = splat;
    my $data_file   = config->{pruebapp}{JSON};
    my $json        = -e $data_file ? read_file $data_file : '{}';
    my $data        = from_json $json;
    my $titulo      = $data->{$articulo}{titulo};
    my $contenido   = $data->{$articulo}{contenido};
    my $fecha       = $data->{$articulo}{fecha};
    template 'articulo', { titulo => $titulo, contenido => $contenido };
};

post '/do' => sub {
    my $titulo      = params->{'titulo'};
    my $contenido   = params->{'contenido'};

    # Si hay contenido
    if ($titulo and $contenido){
        #guardar el contenido.
        my $data_file = config->{pruebapp}{JSON};
        my $json = -e $data_file ? read_file $data_file : '{}';
        my $data = from_json $json;
        my $ya = time;
        my $date = strftime ("%d/%m/%Y", localtime(time()));
        $data->{$ya} = {
            titulo => params->{'titulo'},
            contenido => params->{'contenido'},
            fecha => $date,
        };
        write_file $data_file, to_json $data;
        template '/articulo', { titulo => $titulo, contenido => $contenido };
    } else {
        redirect '/do';
    }
};


true;
