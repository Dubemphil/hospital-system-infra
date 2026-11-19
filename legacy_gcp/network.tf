# ==============================================================================
# Horizon Health Partners - VPC Network & Direct VPC Egress Subnet
# ==============================================================================

# Custom VPC Network
resource "google_compute_network" "custom_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Application Subnet dedicated to Cloud Run Direct VPC Egress
resource "google_compute_subnetwork" "app_subnet" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Cloud Router for Outbound NAT Gateway
resource "google_compute_router" "nat_router" {
  name    = "hhp-nat-router"
  region  = var.region
  network = google_compute_network.custom_vpc.name
}

# Cloud NAT Gateway (Provides secure outbound access for updates without public IPs)
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "hhp-nat-gw"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ------------------------------------------------------------------------------
# Private Services Access (PSA) Peering for Cloud SQL Private IP
# ------------------------------------------------------------------------------

# Reserved Internal IP Range for Cloud SQL
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "hhp-sql-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom_vpc.id
}

# Service Networking Connection to Google Managed Services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.custom_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# ------------------------------------------------------------------------------
# Firewall Rules: Zero Public Ingress
# ------------------------------------------------------------------------------

# Allow internal traffic between Cloud Run Direct VPC Egress subnet and Cloud SQL
resource "google_compute_firewall" "allow_internal" {
  name    = "hhp-allow-internal"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = [var.subnet_cidr]
}

# Allow Google Cloud Identity-Aware Proxy (IAP) for secure administrative bastion
resource "google_compute_firewall" "allow_iap" {
  name    = "hhp-allow-iap"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3306"]
  }

  source_ranges = ["35.235.240.0/20"]
}
