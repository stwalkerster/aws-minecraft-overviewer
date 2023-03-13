resource "aws_ebs_volume" "maps" {
    availability_zone = "eu-west-1b"
    size = 50

    tags = {
      "Name" = "overviewer-maps"
    }
}

resource "aws_ebs_volume" "worlds" {
    availability_zone = "eu-west-1b"
    size = 3

    tags = {
      "Name" = "overviewer-worlds"
    }
}

output "ebs_maps" {
  value = aws_ebs_volume.maps.id
}

output "ebs_worlds" {
  value = aws_ebs_volume.worlds.id
}
