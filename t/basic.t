use strict;
use warnings;

use Test::More;
use Test::Moose::More;

use Trac::API;

# defensively test our public interface
validate_class 'Trac::API' => (
	attributes => [
		'user_agent_class',
		'user_agent_class_traits',
		'ua',
		'auth_string',
		'current_id',
	],
	methods => [

		# public
		'original_user_agent_class',
		'user_agent_class',
		'user_agent_class_traits',
		'ua',
		'auth_string',
		'current_id',
		'call',

		# private
		'_next_id',
	],
);

done_testing;
