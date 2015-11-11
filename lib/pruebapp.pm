package pruebapp;
use Dancer2;
use utf8;
use File::Slurp     qw(read_file write_file);
use POSIX           qw(strftime);

our $VERSION = '0.1';

get '/' => sub {
    my $data_file = config->{pruebapp}{JSON};
    my $autor = config->{pruebapp}{autor};
    my $descripcion = config->{pruebapp}{descripcion};
    my $json = -e $data_file ? read_file $data_file : '{}';
    my $data = from_json $json;
    template 'index', { data => $data, autor => $autor, descripcion => $descripcion};
};

#Mostrar entradas.
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


# Tareas de administración, editar y borrar
#       A no olvidarse de cambiar el password bufarra de las configs.

get '/page/*/ed/*' => sub {
    my ($articulo, $tk) = splat;
    my $passwd_admin = config->{pruebapp}{admin_p};
    if ($tk eq $passwd_admin){
        # editar
        # abrir ese en el formulario y postinguearlo.
        my $data_file = config->{pruebapp}{JSON};
        my $json = -e $data_file ? read_file $data_file : '{}';
        my $data = from_json $json;
        my $titulo_editable = $data->{$articulo}{titulo};
        my $contenido_editable = $data->{$articulo}{contenido};
        # antes de recargar las nuevas cosas, borrar las viejas.
        delete $data->{$articulo};
        write_file $data_file, to_json $data;
        template '/formulario', { titulo => $titulo_editable, contenido => $contenido_editable};
    } else {
        redirect '/';
    }
};

get '/page/*/rm/*' => sub {
    my ($articulo, $tk) = splat;
    my $passwd_admin = config->{pruebapp}{admin_p};
    if ($tk eq $passwd_admin){
        # Borrar
        my $data_file = config->{pruebapp}{JSON};
        my $json = -e $data_file ? read_file $data_file : '{}';
        my $data = from_json $json;
        delete $data->{$articulo};
        write_file $data_file, to_json $data;
        redirect '/';
    } else {
        redirect '/';
    }
};

#Escribir cosillas.
get '/do' => sub {
    template 'formulario';
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
        my $date = strftime ("%d/%m/%Y - %H:%M:%S", localtime(time()));
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
